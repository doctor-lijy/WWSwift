import UIKit
import SnapKit

final class SizeSliderView: UIView {
    var onPercentChanged: ((Float) -> Void)?

    private let slider = UISlider()
    private let percentLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 0
        percentLabel.font = .systemFont(ofSize: 12)
        percentLabel.textColor = .secondaryLabel
        percentLabel.text = "0%"
        slider.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let value = self.slider.value
            self.percentLabel.text = "\(Int(value))%"
            self.onPercentChanged?(value)
        }, for: .valueChanged)

        addSubview(slider)
        addSubview(percentLabel)
        slider.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(percentLabel.snp.leading).offset(-8)
        }
        percentLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        snp.makeConstraints { make in
            make.height.equalTo(36)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
