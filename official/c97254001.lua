--夏
--Summer
local s,id=GetID()
local COUNTER_SEASON=0x214
local CARD_SPRING=60600821
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SEASON)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn: You can place Season Counters on this card equal to the number of your opponent's unused Main Monster Zones
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.countertg)
	e1:SetOperation(s.counterop)
	c:RegisterEffect(e1)
	--Once per turn, when your monster declares an attack: You can inflict 400 damage to your opponent for each Season Counter on this card, and for each "Spring" in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(tp) end)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Once per turn, during your opponent's End Phase: You can take 1 Field Spell from your hand or Deck that you can place a Season Counter on, and place it face-up on your field (but neither player can activate its effects this turn), and if you do, place all Season Counters on this card on that card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_SEASON}
s.listed_names={CARD_SPRING}
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones_count=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if chk==0 then return zones_count>0 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,zones_count,tp,COUNTER_SEASON)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zones_count=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if c:IsRelateToEffect(e) and zones_count>0 then
		c:AddCounter(COUNTER_SEASON,zones_count)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local season_counter_count=e:GetHandler():GetCounter(COUNTER_SEASON)
	local spring_count=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_SPRING)
	local total_damage=400*(season_counter_count+spring_count)
	if chk==0 then return total_damage>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,total_damage)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local player=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local season_counter_count=c:IsRelateToEffect(e) and c:GetCounter(COUNTER_SEASON) or 0
	local spring_count=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_SPRING)
	local total_damage=400*(season_counter_count+spring_count)
	if total_damage>0 then
		Duel.Damage(player,total_damage,REASON_EFFECT)
	end
end
function s.plfilter(c)
	return c:IsFieldSpell() and c:IsCanAddCounter(COUNTER_SEASON,1,false,LOCATION_ONFIELD) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetHandler():GetCounter(COUNTER_SEASON),tp,COUNTER_SEASON)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc then return end
	local c=e:GetHandler()
	local ct=c:GetCounter(COUNTER_SEASON)
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	if Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
		--Neither player can activate its effects this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
		if ct>0 then
			sc:AddCounter(COUNTER_SEASON,ct)
		end
	end
end