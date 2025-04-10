--時の機械－タイム・エンジン
--Time Engine
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster you controlled that was destroyed by battle or an opponent's card effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Keep track of the destroyed monsters
	aux.GlobalCheck(s,function()
		s.desgroup=Group.CreateGroup()
		s.desgroup:KeepAlive()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.desgroupregop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_METALMORPH}
function s.desgroupregopfilter(c)
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:IsReasonPlayer(1-c:GetPreviousControler())))
		and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.desgroupregop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.desgroupregopfilter,nil)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		if Duel.GetCurrentChain()==0 then s.desgroup:Clear() end
		s.desgroup:Merge(tg)
		s.desgroup:Remove(function(c) return not c:HasFlagEffect(id) end,nil)
		Duel.RaiseEvent(s.desgroup,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.spfilter(c,e,tp)
	return c:IsPreviousControler(tp) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=s.desgroup:Filter(s.spfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) and s.spfilter(chkc,e,tp) end
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local tg=nil
	if #g==1 then
		tg=g
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tg=g:Select(tp,1,1,nil)
	end
	Duel.SetTargetCard(tg)
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tg:GetFirst():GetBaseAttack())
end
function s.metalmorphfilter(c)
	return c:IsSetCard(SET_METALMORPH) and c:IsTrap() and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:IsLevelAbove(5) and tc:IsRace(RACE_MACHINE)
		and Duel.IsExistingMatchingCard(s.metalmorphfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,exc)
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
		if #dg==0 then return end
		local atk=tc:GetBaseAttack()
		Duel.BreakEffect()
		if Duel.Destroy(dg,REASON_EFFECT)>0 and tc:IsFaceup() and atk>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end