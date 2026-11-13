--アサルト・スラッシュ・ワイバーン
--Assault Slash Wyvern
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can send to the GY, or banish, 1 "Blue-Eyes" monster from your Deck
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.tgtg)
	e1a:SetOperation(s.tgop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If you have a banished "Blue-Eyes" monster: You can Tribute this card; Special Summon 1 "Blue-Eyes White Dragon" or 1 monster that mentions "Endless Darkness", except "Assault Slash Wyvern", from your Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON,CARD_ENDLESS_DARKNESS,id}
s.listed_series={SET_BLUE_EYES}
function s.tgrmfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and (c:IsAbleToGrave() or c:IsAbleToRemove())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgrmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectMatchingCard(tp,s.tgrmfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	local choice=Duel.SelectEffect(tp,
		{tc:IsAbleToGrave(),aux.Stringid(id,3)},
		{tc:IsAbleToRemove(),aux.Stringid(id,4)})
	if choice==1 then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	elseif choice==2 then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.blueyesfilter(c)
	return c:IsSetCard(SET_BLUE_EYES) and c:IsMonster() and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.blueyesfilter,tp,LOCATION_REMOVED,0,1,nil)
end
function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_BLUEEYES_W_DRAGON) or c:ListsCode(CARD_ENDLESS_DARKNESS)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end