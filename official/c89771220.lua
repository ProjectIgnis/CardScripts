--天斗輝巧極
--Ursarctic Drytron
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If you would Tribute a monster(s) to activate an "Ursarctic" or "Drytron" monster's effect, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(CARD_URSARCTIC_BIG_DIPPER)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsAbleToRemoveAsCost() end)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(CARD_URSARCTIC_DRYTRON)
	c:RegisterEffect(e3)
end
s.listed_names={33250142,CARD_URSARCTIC_BIG_DIPPER,58793369,27693363,97148796}
--"Ultimate Flagship Ursatron", "Ursarctic Big Dipper", "Drytron Fafnir", "Ursarctic Polari", "Drytron Alpha Thuban"
s.listed_series={SET_URSARCTIC,SET_DRYTRON}
function s.rmfilter(c)
	return c:IsCode(CARD_URSARCTIC_BIG_DIPPER,58793369) and c:IsAbleToRemove()
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==2 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.spfilter(c,e,tp,sg)
	return c:IsCode(33250142) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local locations=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,27693363,97148796),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK
		or LOCATION_HAND|LOCATION_ONFIELD
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,locations,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,locations)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local locations=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,27693363,97148796),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK
		or LOCATION_HAND|LOCATION_ONFIELD
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,locations,0,nil)
	if #g<=1 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	if #rg==2 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		Duel.BreakEffect()
		if Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end 
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsSetCard({SET_URSARCTIC,SET_DRYTRON}) and c:IsMonster() and (extracon==nil or extracon(base,e,tp,eg,ep,ev,re,r,rp))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST|REASON_REPLACE)
end