--捕食生成
--Predaplast
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={0xf3,0x10f3}
s.counter_place_list={COUNTER_PREDATOR}
function s.cfilter(c)
	return c:IsSetCard(0xf3) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local hg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,e:GetHandler())
	local ct=Duel.GetTargetCount(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,COUNTER_PREDATOR,1)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(COUNTER_PREDATOR,1) end
	if chk==0 then return #hg>0 and ct>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=hg:Select(tp,1,ct,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,#g,#g,nil,COUNTER_PREDATOR,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		if tc:AddCounter(COUNTER_PREDATOR,1) and tc:GetLevel()>1 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
	end
end
function s.lvcon(e)
	return e:GetHandler():GetCounter(COUNTER_PREDATOR)>0
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x10f3) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
