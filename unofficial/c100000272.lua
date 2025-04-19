--血の咆哮－ブラッド・ロアー
--Plasma Roar
local s,id=GetID()
function s.initial_effect(c)
	--Counter Permit (Plasma Counter)
	c:EnableCounterPermit(0x92)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_DRAW_PHASE)
	c:RegisterEffect(e1)
	--Place 1 Plasma Counter on this card during your opponent's Standby Phase
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.countercon)
	e2:SetOperation(s.counterop)
	c:RegisterEffect(e2)
	--Destroy 1 monster and inflict damage to your opponent
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_names={83965310} --Destiny HERO - Plasma
s.counter_place_list={0x92}
function s.countercon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,83965310),tp,LOCATION_MZONE,0,1,nil)
	 and e:GetHandler():IsCanAddCounter(0x92,1)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsFaceup() and c:IsRelateToEffect(e) then
		c:AddCounter(0x92,1)
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():GetCounter(0x92)>1 end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,atk/2,REASON_EFFECT)
		end
	end
end