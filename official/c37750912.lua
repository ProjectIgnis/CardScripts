--スターダスト・イルミネイト
--Stardust Illumination
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--To Grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Level Change
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_STARDUST_DRAGON}
s.listed_series={SET_STARDUST}
--To Grave
function s.ssfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_STARDUST_DRAGON) or (c:ListsCode(CARD_STARDUST_DRAGON) and c:IsType(TYPE_SYNCHRO)))
end
function s.tgfilter(c,e,tp,ss,mz)
	return c:IsMonster() and c:IsSetCard(SET_STARDUST) and (c:IsAbleToGrave() or (ss and mz and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ss,mz=Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_MZONE,0,1,nil),Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ss,mz) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ss,mz=Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_MZONE,0,1,nil),Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ss,mz)
	if #g>0 then
		if ss and mz and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
--Level Change
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_STARDUST) and c:IsMonster() and c:HasLevel()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	local tc=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local choice=-1
	if tc:IsLevelAbove(2) then 
		choice=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
	else
		choice=Duel.SelectOption(tp,aux.Stringid(id,4))
	end
	--Change Level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	e1:SetValue(1-(choice*2))
	tc:RegisterEffect(e1)
end