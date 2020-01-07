--エクシーズ熱戦！！
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsPreviousControler(tp) and (not e or c:IsRelateToEffect(e))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,nil,tp) and eg:IsExists(s.cfilter,1,nil,nil,1-tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.filter(c,e,tp,eg)
	return c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
		and eg:IsExists(s.rkfilter,1,nil,c:GetRank(),tp)
end
function s.rkfilter(c,rk,tp)
	return c:GetRank()==rk and c:IsPreviousControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and Duel.GetLocationCountFromEx(1-tp)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,eg) 
		and Duel.GetFieldGroupCount(1-tp,LOCATION_EXTRA,0)>0 end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Group.CreateGroup()
	local tc1=nil
	local tc2=nil
	local tg1=eg:Filter(s.cfilter,nil,e,tp)
	local tg2=eg:Filter(s.cfilter,nil,e,1-tp)
	local fid=e:GetHandler():GetFieldID()
	if Duel.GetLocationCountFromEx(tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tc1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,eg):GetFirst()
		local pos=POS_FACEUP
		if Duel.GetTurnPlayer()==tp then pos=POS_FACEUP_ATTACK end
		if tc1 and Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,pos) then
			tc1:RegisterFlagEffect(51102757,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1,fid)
		end
	end
	if Duel.GetLocationCountFromEx(1-tp)>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		tc2=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_EXTRA,0,1,1,nil,e,1-tp,eg):GetFirst()
		local pos=POS_FACEUP
		if Duel.GetTurnPlayer()~=tp then pos=POS_FACEUP_ATTACK end
		if tc2 and Duel.SpecialSummonStep(tc2,0,1-tp,1-tp,false,false,pos) then
			tc2:RegisterFlagEffect(51102757,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1,fid)
		end
	end
	Duel.SpecialSummonComplete()
	if tc1 then
		sg:AddCard(tc1)
		Duel.Overlay(tc1,tg1)
	end
	if tc2 then
		sg:AddCard(tc2)
		Duel.Overlay(tc2,tg2)
	end
	if tc1 and tc2 then
		if Duel.GetTurnPlayer()==tp then
			Duel.CalculateDamage(tc1,tc2)
		else
			Duel.CalculateDamage(tc2,tc1)
		end
	end
	sg:KeepAlive()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(sg)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	Duel.RegisterEffect(e1,tp)
end
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(51102757)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	Duel.Destroy(tg,REASON_EFFECT)
end
