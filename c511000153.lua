--Kuribah
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86585274,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={511000150}
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),511000152,511000151,40640057,id+1)
end
function s.chk(c,sg,g,code,...)
	if not c:IsCode(code) then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.cfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil,511000152)
	local g2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil,511000151)
	local g3=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil,40640057)
	local g4=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil,id+1)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	g:Merge(g4)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-5 and #g1>0 and #g2>0 and #g3>0 and #g4>0 
		and c:IsAbleToRemoveAsCost() and aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,1,tp,HINTMSG_REMOVE)
	sg:AddCard(c)
	sg:KeepAlive()
	e:SetLabelObject(sg)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsCode(511000150) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0x13,0,1,nil,e,tp) end
	Duel.SetTargetCard(e:GetLabelObject())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,0x13,0,1,1,nil,e,tp):GetFirst()
	if tc then
		tc:SetMaterial(g)
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
