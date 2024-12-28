--冥骸合竜－メメントラル・テクトリカ
--Mementoal Tecuhtlica - Combined Creation
--Scripted by Satellaa
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot Special Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--Special Summon itself from the hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
	--Can attack all monsters your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	e2:SetCondition(function(e) return Duel.GetMatchingGroupCount(nil,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())==0 end)
	c:RegisterEffect(e2)
	--Special Summon 1 "Memento" monster from your hand or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(_,tp,_,ep) return ep==1-tp end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MEMENTO}
function s.tdfilter(c)
	return c:IsSetCard(SET_MEMENTO) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,e:GetHandler())
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.SelectUnselectGroup(rg,e,tp,5,5,aux.dncheck,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,5,5,aux.dncheck,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spprocop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MEMENTO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end