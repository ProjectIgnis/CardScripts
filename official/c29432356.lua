--智天の神星龍
--Zefraath
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c)
	c:AddMustBeSpecialSummoned()
	--Must be Special Summoned (from your face-up Extra Deck) by Tributing all monsters you control, including at least 3 "Zefra" monsters
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.selfspcon)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
	--Add 1 "Zefra" Pendulum Monster from your Deck to your Extra Deck, face-up, and if you do, change this card's Pendulum Scale to be the same as that Pendulum Monster's, until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.textg)
	e1:SetOperation(s.texop)
	c:RegisterEffect(e1)
	--After you Special Summon this card, you can conduct 1 Pendulum Summon of a "Zefra" monster(s) during your Main Phase this turn, in addition to your Pendulum Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(function(e,tp) Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),function(c) return c:IsSetCard(SET_ZEFRA) end,tp,LOCATION_HAND|LOCATION_EXTRA,aux.Stringid(id,2),aux.Stringid(id,3),id) end)
	c:RegisterEffect(e2)
	--Special Summon 1 "Zefra" monster from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.deckspcost)
	e3:SetTarget(s.decksptg)
	e3:SetOperation(s.deckspop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ZEFRA}
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local rg=Duel.GetReleaseGroup(tp)
	return (#g>0 or #rg>0) and g:FilterCount(Card.IsReleasable,nil)==#g
		and g:FilterCount(Card.IsSetCard,nil,SET_ZEFRA)>=3
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp)
	Duel.Release(rg,REASON_COST)
end
function s.texfilter(c,scale)
	return c:IsSetCard(SET_ZEFRA) and c:IsType(TYPE_PENDULUM) and not c:IsScale(scale)
end
function s.textg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.texfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetScale()) end
end
function s.texop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))
	local sc=Duel.SelectMatchingCard(tp,s.texfilter,tp,LOCATION_DECK,0,1,1,nil,c:GetScale()):GetFirst()
	if sc and Duel.SendtoExtraP(sc,tp,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_EXTRA) then
		--Change this card's Pendulum Scale to be the same as that Pendulum Monster's, until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(sc:GetLeftScale())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		e2:SetValue(sc:GetRightScale())
		c:RegisterEffect(e2)
	end
end
function s.deckspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,aux.ReleaseCheckMMZ,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,aux.ReleaseCheckMMZ,nil)
	Duel.Release(g,REASON_COST)
end
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(SET_ZEFRA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.decksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.deckspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end