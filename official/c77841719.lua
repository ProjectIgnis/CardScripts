--ヴェルズ・コッペリアル
--Evilswarm Coppelia
local s,id=GetID()
function s.initial_effect(c)
	c:AddCannotBeSpecialSummoned()
	--Take control of 1 face-up monster your opponent controls until your next End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(s.controlcon)
	e1:SetTarget(s.controltg)
	e1:SetOperation(s.controlop)
	c:RegisterEffect(e1)
end
function s.controlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and rp==1-tp
end
function s.controltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() and chkc:IsFaceup() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
	end
end
function s.controlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local ct=(Duel.IsTurnPlayer(1-tp) and 2)
			or (Duel.IsPhase(PHASE_END) and 3)
			or 1
		Duel.GetControl(tc,tp,PHASE_END,ct)
	end
end