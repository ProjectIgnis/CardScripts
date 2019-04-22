--sophiaの影霊衣
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--cannot spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--remove
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.rmcon)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():IsLocation(LOCATION_HAND) and (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
function s.mat_filter(c)
	return false
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==1 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e3,tp)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,false,true))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function s.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.ritual_custom_condition(c,mg,ft,rittype)
	local tp=c:GetControler()
	local g=mg:Filter(s.filter,c,tp)
	return ft>-3 and g:IsExists(s.ritfilter1,1,nil,c:GetLevel(),g,c,rittype)
end
function s.ritfilter1(c,lv,mg,sc,rittype)
	local mg2=mg:Clone()
	mg2:Remove(Card.IsRace,nil,c:GetRace())
	return mg2:IsExists(s.ritfilter2,1,c,lv,mg2,Group.CreateGroup()+c,sc,rittype)
end
function s.ritfilter2(c,lv,mg,sg,sc,rittype)
	local mg2=mg:Clone()
	mg2:Remove(Card.IsRace,nil,c:GetRace())
	return mg2:IsExists(s.ritfilter3,1,sg,lv,sg+c,sc,rittype)
end
function s.ritfilter3(c,lv,sg,sc,rittype)
	if rittype=="equal" then
		return (sg+c):CheckWithSumEqual(Card.GetRitualLevel,lv,3,3,sc)
	else
		Duel.SetSelectedCard(sg+c)
		return (sg+c):CheckWithSumGreater(Card.GetRitualLevel,lv,sc)
	end
end
function s.ritual_custom_operation(c,mg,rittype)
	local tp=c:GetControler()
	local lv=c:GetLevel()
	local g=mg:Filter(s.filter,c,tp)
	local sg=Group.CreateGroup()
	while #sg<3 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		if #sg==0 then
			sg = sg + g:Filter(s.ritfilter1,nil,lv,g,c,rittype):SelectUnselect(sg,tp,false,false,lv)
		elseif #sg==1 then
			local tc = g:Filter(s.ritfilter2,sg,lv,g,sg,c,rittype):Filter(function(c,sg)
				return not sg:IsExists(Card.IsRace,1,nil,c:GetRace()) end,nil,sg):SelectUnselect(sg,tp,false,false,lv)
			if sg:IsContains(tc) then
				sg=sg-tc
			else
				sg=sg+tc
			end
		elseif #sg==2 then
			local tc = g:Filter(s.ritfilter3,sg,lv,sg,c,rittype):Filter(function(c,sg)
				return not sg:IsExists(Card.IsRace,1,nil,c:GetRace()) end,nil,sg):SelectUnselect(sg,tp,false,false,lv)
			if sg:IsContains(tc) then
				sg=sg-tc
			else
				sg=sg+tc
			end
		end
	end
	c:SetMaterial(sg)
end
