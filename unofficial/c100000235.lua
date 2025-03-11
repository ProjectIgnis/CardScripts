--異次元格納庫
--Different Dimension Hangar
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.retarget)
	e1:SetOperation(s.reactivate)
	c:RegisterEffect(e1)
	local sg=Group.CreateGroup()
	sg:KeepAlive()
	e1:SetLabelObject(sg)
	--Special Summon the banished Unions
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	e2:SetLabelObject(sg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.refilter(c)
	return c:IsType(TYPE_UNION) and c:IsLevelBelow(4) and c:IsAbleToRemove()
end
function s.retarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
function s.reactivate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.refilter,tp,LOCATION_DECK,0,nil)
	if #g<3 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,3,3,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	local sg=e:GetLabelObject()
	if c:GetFlagEffect(id)==0 then
		sg:Clear()
		c:RegisterFlagEffect(id,RESET_EVENT|0x1680000,0,1)
	end
	local tc=rg:GetFirst()
	for tc in aux.Next(rg) do
		sg:AddCard(tc)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
	end
end
function s.filter(c,e,tp)
	local g=e:GetLabelObject()
	return c:IsFaceup() and c:IsControler(tp) and g:IsExists(s.filter2,1,nil,c,e,tp)
end
function s.filter2(c,eqc,e,tp)
	return c:GetFlagEffect(id)~=0 and c:ListsCode(eqc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(s.filter,1,nil,e,tp) end
	local g=e:GetLabelObject()
	local gt=eg:Filter(s.filter,nil,e,tp)
	local gtg=gt:GetFirst()
	local tg=Group.CreateGroup()
	local tdg=nil
	for gtg in aux.Next(gt) do
		tdg=g:Filter(s.filter2,nil,gtg,e,tp)
		if #tdg>0 then
			tg:Merge(tdg)
		end
	end
	Duel.SetTargetCard(tg)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft>#tg then ft=#tg end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,ft,tp,LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=nil
	local tg=Duel.GetTargetCards(e)
	if #tg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if #g==0 then return end
	local c=e:GetHandler()
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			--Cannot attack
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3206)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			--Cannot be Tributed
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(3303)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UNRELEASABLE_SUM)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			e2:SetValue(1)
			tc:RegisterEffect(e2,true)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			tc:RegisterEffect(e3,true)
		end
		Duel.SpecialSummonComplete()
	end
end
