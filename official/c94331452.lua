--音響戦士ドラムス
--Symphonic Warrior Drumss
local s,id=GetID()
function s.initial_effect(c)
	--attribute change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target(LOCATION_MZONE))
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target(0))
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x1066}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066)
end
function s.target(oppo)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and (oppo==0 or chkc:IsControler(tp)) and s.filter(chkc) and chkc:IsDifferentAttribute(e:GetLabel()) end
		if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,oppo,1,nil) end
		local g=Duel.GetMatchingGroup(aux.AND(s.filter,Card.IsCanBeEffectTarget),tp,LOCATION_MZONE,oppo,nil,e)
		local att=Duel.AnnounceAnotherAttribute(g,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sel=g:FilterSelect(tp,Card.IsDifferentAttribute,1,1,nil,att)
		Duel.SetTargetCard(sel)
		e:SetLabel(att)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
