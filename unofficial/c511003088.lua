--BK リベージ・ガードナー (Anime)
--Battlin' Boxer Rib Gardna (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--change target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54912977,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_REPLACE and Duel.GetAttackTarget()==e:GetHandler()
		and e:GetHandler():GetBattlePosition()&POS_FACEDOWN_DEFENSE==POS_FACEDOWN_DEFENSE
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local a=Duel.GetAttacker()
	if tc and tc:IsRelateToEffect(e) and a and a:CanAttack() and not a:IsImmuneToEffect(e) then
		Duel.CalculateDamage(a,tc)
		if a:IsControler(1-tp) and a:IsType(TYPE_XYZ) then
			local og=a:GetOverlayGroup()
			if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(81330115,1)) then
				Duel.SendtoGrave(og,REASON_EFFECT)
			end
		end
	end
end