--Ｐ.Ｕ.Ｎ.Ｋ. ＪＡＭドラゴン・ドライブ
--P.U.N.K. JAM Dragon Drive
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PSYCHIC),1,1,Synchro.NonTuner(nil),1,99)
	--Search or send to the GY 1 "P.U.N.K." monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.thgcon)
	e1:SetCost(Cost.PayLP(600))
	e1:SetTarget(s.thgtg)
	e1:SetOperation(s.thgop)
	c:RegisterEffect(e1)
	--Special Summon itself from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PUNK}
function s.thgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSynchroSummoned() or 
		(re and re:GetHandler():IsSetCard(SET_PUNK))
end
function s.thgfilter(c)
	return c:IsLevel(3) and c:IsRace(RACE_PSYCHIC) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thgfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain()-1
	if ch<=0 then return false end
	local cplayer=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)
	local ceff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
	return ep==1-tp and cplayer==tp and ceff:GetHandler():IsSetCard(SET_PUNK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end