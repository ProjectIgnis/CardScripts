--マシュマオ☆ヤミー
--Marshmao☆Yummy
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 "Yummy" Spell/Trap from your GY to your hand, or, if this card was Special Summoned by the effect of a Synchro Monster, you can place 1 "Yummy" Field Spell or "Yummy" Continuous Spell/Trap from your Deck or banishment face-up on your field instead
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetTarget(s.thpltg)
	e2a:SetOperation(s.thplop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_YUMMY}
function s.spconfilter(c)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST) and c:IsFaceup())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_YUMMY) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.plfilter(c,tp,szone_chk)
	return c:IsSetCard(SET_YUMMY) and (c:IsFieldSpell() or (szone_chk and c:IsContinuousSpellTrap()))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.thpltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp_chk=re and e:GetHandler():IsSpecialSummoned() and re:IsMonsterEffect() and re:GetHandler():IsOriginalType(TYPE_SYNCHRO)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		or (sp_chk and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil,tp,Duel.GetLocationCount(tp,LOCATION_SZONE)>0)) end
	e:SetLabel(sp_chk and 1 or 0)
	if sp_chk then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	else
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
function s.thplop(e,tp,eg,ep,ev,re,r,rp)
	local sp_chk=e:GetLabel()==1
	local szone_chk=sp_chk and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
	if sp_chk then
		g:Merge(Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,nil,tp,szone_chk))
	end
	if #g==0 then return end
	local hint=sp_chk and aux.Stringid(id,2) or HINTMSG_ATOHAND
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
	if sc:IsLocation(LOCATION_GRAVE) then
		--Add 1 "Yummy" Spell/Trap from your GY to your hand
		Duel.HintSelection(sc)
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
	else
		--Place 1 "Yummy" Field Spell or "Yummy" Continuous Spell/Trap from your Deck or banishment face-up on your field
		if sc:IsLocation(LOCATION_REMOVED) then Duel.HintSelection(sc) end
		local place_location=sc:IsFieldSpell() and LOCATION_FZONE or LOCATION_SZONE
		Duel.MoveToField(sc,tp,tp,place_location,POS_FACEUP,true)
	end
end