--ギャラルホルン (VG)
--Gjallarhorn (VG)
local s,id=GetID()
function s.initial_effect(c)
	--Activate this card from your Gravyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_FORCE_ACTIVATE_LOCATION)
	e1:SetValue(LOCATION_SZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_AESIR}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(SET_AESIR) end
	if chk==0 then
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_AESIR),tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_AESIR),tp,LOCATION_MZONE,0,1,1,nil)
	--Turn Counter
	c:SetTurnCounter(0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(3)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetOperation(s.remop)
	e2:SetReset(RESETS_STANDARD_PHASE_END|RESET_SELF_TURN,3)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(1082946)
	e3:SetLabelObject(e2)
	e3:SetOwnerPlayer(tp)
	e3:SetOperation(s.reset)
	e3:SetReset(RESETS_STANDARD_PHASE_END|RESET_SELF_TURN,3)
	c:RegisterEffect(e3)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.remop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(function(e,te) return te:IsSpellTrapEffect() end)
		e3:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e3)
	end
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e2:SetCode(id)
		e2:SetCountLimit(1)
		e2:SetTarget(s.damtg)
		e2:SetOperation(s.damop)
		e2:SetReset(RESETS_STANDARD_PHASE_END|RESET_SELF_TURN)
		c:RegisterEffect(e2)
		c:ResetFlagEffect(1082946)
		Duel.RaiseSingleEvent(c,id,e,r,rp,ep,0)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	g:Match(Card.IsFaceup,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetSum(Card.GetAttack))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,nil)
	local g2=g:Filter(Card.IsFaceup,nil)
	local sum=g2:GetSum(Card.GetAttack)
	Duel.Damage(1-tp,sum,REASON_EFFECT)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
