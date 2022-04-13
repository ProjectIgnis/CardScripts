--ラヴェナス・ヴェンデット
--Ravenous Vendread
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	local rparams={handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.matfilter,extrafil=s.extrafil,location=LOCATION_HAND|LOCATION_GRAVE,forcedselection=s.ritcheck}
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target(Ritual.Target(rparams)))
	e1:SetOperation(s.operation(Ritual.Target(rparams),Ritual.Operation(rparams)))
	c:RegisterEffect(e1)
end
s.listed_series={0x106}
s.listed_names={101109040}
function s.ritualfil(c)
	return c:IsSetCard(0x106) and c:IsRitualMonster()
end
function s.matfilter(c,e,tp)
	return (Duel.IsPlayerCanRelease(tp,c) and c:IsLocation(LOCATION_MZONE)) or s.extramatfil(c,e,tp)
end
function s.extramatfil(c,e,tp)
	return c:IsSetCard(0x106) and not c:IsCode(101109040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.extrafil(e,tp,mg)
	if not Duel.IsPlayerCanRelease(tp) then return nil end
	return Duel.GetMatchingGroup(s.extramatfil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
end
function s.ritcheck(e,tp,g,sc)
	local obj=e:GetLabelObject()
	local res=obj and g:IsContains(obj)
	local ct=g:FilterCount(aux.NOT(Card.IsLocation),obj,LOCATION_MZONE)
	return res and ct==0,not res and ct~=0
end
function s.spfilter(c,e,tp,eg,ep,ev,re,r,rp,rittg)
	if not s.extramatfil(c,e,tp) then return false end
	e:SetLabelObject(c)
	local res=rittg(e,tp,eg,ep,ev,re,r,rp,0)
	e:SetLabelObject(nil)
	return res
end
function s.target(rittg)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp,rittg) end
		rittg(e,tp,eg,ep,ev,re,r,rp,1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	end
end
function s.operation(rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp,rittg)
		if #sg==0 then return end
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			Duel.ConfirmCards(1-tp,sg)
			Duel.BreakEffect()
			e:SetLabelObject(sg:GetFirst())
			ritop(e,tp,eg,ep,ev,re,r,rp)
			e:SetLabelObject(nil)
		end
	end
end