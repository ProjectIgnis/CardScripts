--輝光帝ギャラクシオン
--Starliege Lord Galaxion
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PHOTON),4,2)
	c:EnableReviveLimit()
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1,false,EFFECT_MARKER_DETACH_XMAT)
end
s.listed_series={SET_PHOTON}
s.listed_names={CARD_GALAXYEYES_P_DRAGON}
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_GALAXYEYES_P_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (b1 or b2) end
	local opt=0
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(opt)
	e:GetHandler():RemoveOverlayCard(tp,opt+1,opt+1,REASON_COST)
	if opt==0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=nil
	if e:GetLabel()==0 then
		tc=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	else
		tc=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	end
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end