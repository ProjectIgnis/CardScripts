--ネクロバレーの神殿
--Necrovalley Temple
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP)
	e0:SetCondition(aux.StatChangeDamageStepCondition)
	c:RegisterEffect(e0)
	--While a "Gravekeeper's" monster(s) and "Necrovalley" are both on the field, monsters your opponent controls lose 500 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	--Decrease DEF
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Once per turn, during the Main Phase, if you control no card in your Field Zone: You can activate 1 "Necrovalley" directly from your hand or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCondition(s.accon)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
	--f this card in your possession is destroyed by an opponent's effect and sent to your GY: You can Set 1 "Necrovalley" Spell/Trap directly from your Deck, except "Necrovalley Temple"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GRAVEKEEPERS,SET_NECROVALLEY}
s.listed_names={CARD_NECROVALLEY,id}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GRAVEKEEPERS),e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsEnvironment(CARD_NECROVALLEY)
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,tp)
		and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_FZONE,0,1,nil)
end
function s.filter(c,tp)
	return c:IsCode(CARD_NECROVALLEY) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
function s.setfilter(c)
	return c:IsSetCard(SET_NECROVALLEY) and not c:IsCode(id) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
	end
end