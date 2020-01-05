--ペンデュラム・シフト
--Pendulum Transfer
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return s.count_free_pendulum_zones(tp) > 0
						and (Duel.GetLocationCount(tp,LOCATION_SZONE) > 1 or e:GetHandler():IsLocation(LOCATION_SZONE))
						and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,s.count_free_pendulum_zones(tp),nil)
end
function s.count_free_pendulum_zones(tp)
	local count = 0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then
		count = count + 1
	end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		count = count + 1
	end
	return count
end
function s.move_to_pendulum_zone(c,tp,e)
	if not c or not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		or not c:IsRelateToEffect(e) or not (c:IsControler(tp) and s.filter(c)) then return end

	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		s.move_to_pendulum_zone(g:GetFirst(),tp,e)
		s.move_to_pendulum_zone(g:GetNext(),tp,e)
	end
end