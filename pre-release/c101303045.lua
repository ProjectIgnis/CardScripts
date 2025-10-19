--ガンホー！スプリガンズ！
--Gung-ho! Springans!
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 4 "Springans" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SPRINGANS),4,2,nil,nil,Xyz.InfiniteMats)
	--Special Summon 1 "Springans Captain Sargas" from your Deck or GY
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_TO_GRAVE)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	c:RegisterEffect(e1b)
	--Add to your hand, or Special Summon, 1 "Springans" or "Therion" monster or "Fallen of Albaz" or monster that mentions it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.DetachFromSelf(2))
	e2:SetTarget(s.thsptg)
	e2:SetOperation(s.thspop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ALBAZ,29601381} --"Springans Captain Sargas" 
s.listed_series={SET_SPRINGANS,SET_THERION}
function s.spfilter(c,e,tp)
	return c:IsCode(29601381) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
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
function s.thspfilter(c,e,tp,mmz_chk)
	return (c:IsSetCard({SET_SPRINGANS,SET_THERION}) or (c:IsCode(CARD_ALBAZ) or c:ListsCode(CARD_ALBAZ))) and c:IsMonster()
		and (c:IsAbleToHand() or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,
		function()
			return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,3)
	)
end