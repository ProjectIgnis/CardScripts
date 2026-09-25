--秋
--Autumn
--scripted by pyrQ
local s,id=GetID()
local CARD_SUMMER=97254001
local COUNTER_SEASON=0x214
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SEASON)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--This card's name becomes "Summer" while in the Field Zone
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetValue(CARD_SUMMER)
	c:RegisterEffect(e1)
	--Once per turn: You can place Season Counters on this card equal to the number of cards in your opponent's hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.countertg)
	e2:SetOperation(s.counterop)
	c:RegisterEffect(e2)
	--At the start of the Battle Phase: You can take 1 Field Spell from your hand, Deck, or GY that you can place a Season Counter on, except "Autumn", and place it face-up on your field, and if you do, place all Season Counters on this card on that card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
	--If a card(s) in the Field Zone would be destroyed by card effect, you can banish this card from your GY instead
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTarget(s.reptg)
	e4:SetValue(function(e,c)
		return s.repfilter(c,e:GetHandlerPlayer())
	end)
	e4:SetOperation(function(e)
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
	end)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_SUMMER,id}
s.counter_place_list={COUNTER_SEASON}
local LOCATIONS_HAND_DECK_GRAVE=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local opp_hand_count=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if chk==0 then return opp_hand_count>0 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,opp_hand_count,tp,COUNTER_SEASON)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opp_hand_count=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if c:IsRelateToEffect(e) and opp_hand_count>0 then
		c:AddCounter(COUNTER_SEASON,opp_hand_count)
	end
end
function s.plfilter(c)
	return c:IsFieldSpell() and c:IsCanAddCounter(COUNTER_SEASON,1,false,LOCATION_ONFIELD) and not c:IsCode(id) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATIONS_HAND_DECK_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetHandler():GetCounter(COUNTER_SEASON),tp,COUNTER_SEASON)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATIONS_HAND_DECK_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	local c=e:GetHandler()
	local ct=c:GetCounter(COUNTER_SEASON)
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	if Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) and ct>0 then
		sc:AddCounter(COUNTER_SEASON,ct)
	end
end
function s.repfilter(c)
	return c:IsLocation(LOCATION_FZONE) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil) end
	return Duel.SelectEffectYesNo(tp,c,96)
end