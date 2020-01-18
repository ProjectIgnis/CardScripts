--異次元格納庫
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
	--SPSUMMON
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	e3:SetLabelObject(sg)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.refilter(c)
	return c:IsType(TYPE_UNION) and c:IsLevelBelow(4) and c:IsAbleToRemove()
end
function s.retarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.reactivate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.refilter,tp,LOCATION_DECK,0,1,3,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local sg=e:GetLabelObject()
		if c:GetFlagEffect(id)==0 then
			sg:Clear()
			c:RegisterFlagEffect(id,RESET_EVENT+0x1680000,0,1)
		end
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			sg:AddCard(tc)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
function s.filter(c,e,tp)
	local g=e:GetLabelObject()
	return c:IsFaceup() and c:IsSummonPlayer(tp) and g:IsExists(s.filter2,1,nil,c,e,tp)
end
function s.filter2(c,eqc,e,tp)
	return c:GetFlagEffect(id)~=0 and c:CheckEquipTarget(eqc) and aux.IsCodeListed(c,eqc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(s.filter,1,nil,e,tp) end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local gc=Duel.GetLocationCount(tp,LOCATION_MZONE)
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
	local sg=tg:Select(tp,1,gc,nil)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,gc,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g then return end
	local c=e:GetHandler()
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(1)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)	
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(1)
			tc:RegisterEffect(e2,true)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			tc:RegisterEffect(e3,true)
		end
		Duel.SpecialSummonComplete()
	end
end