--氷結界の鏡魔師
--Mirror Mage of the Ice Barrier
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon up to 3 "Ice Barrier Tokens"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	--Add 1 "Ice Barrier" card to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
TOKEN_ICE_BARRIER=44308318
s.listed_names={id,TOKEN_ICE_BARRIER}
s.listed_series={SET_ICE_BARRIER}
function s.tkcostfilter(c,tp)
	return c:IsType(TYPE_EFFECT) and Duel.GetMZoneCount(tp,c)>0
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.tkcostfilter,1,false,nil,c,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.tkcostfilter,1,1,false,nil,c,tp)
	Duel.Release(g,REASON_COST)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():HasLevel()
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ICE_BARRIER,SET_ICE_BARRIER,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except WATER Synchro Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_WATER)) and c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(_,c) return not c:IsOriginalType(TYPE_SYNCHRO) or not c:IsOriginalAttribute(ATTRIBUTE_WATER) end)
	local ft=math.min(3,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft==0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ICE_BARRIER,SET_ICE_BARRIER,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=Duel.AnnounceNumberRange(tp,1,ft)
	for i=1,ct do
		local token=Duel.CreateToken(tp,TOKEN_ICE_BARRIER)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	ct=Duel.SpecialSummonComplete()
	if ct and ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		c:UpdateLevel(ct)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_ICE_BARRIER) and c:IsAbleToHand() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
		and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end