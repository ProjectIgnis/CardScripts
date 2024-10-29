--原始生命態ティア
--Theia, the Primal Being
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Neither player can Normal and/or Special Summon more than 4 times per turn while this card is face-up in the Monster Zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetTargetRange(1,1)
	e2:SetTarget(function(e,c,tp) return e:GetHandler():GetFlagEffect(id+tp)>=4 end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e3)
	--Register a flag to this card everytime Normal and Special Summons happen
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e,tp,eg) return eg and not eg:IsContains(e:GetHandler()) end)
	e4:SetOperation(function(e,tp,eg,ep) e:GetHandler():RegisterFlagEffect(id+ep,RESETS_STANDARD_PHASE_END,0,1) end)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--Special Summon left count
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(1,1)
	e6:SetValue(s.countval)
	c:RegisterEffect(e6)
end
function s.spcheck(sg,tp)
	return aux.ReleaseCheckMMZ(sg,tp) and not sg:IsExists(Card.IsLevelBelow,1,nil,sg:GetSum(Card.GetLevel)-11)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.HasLevel,1,99,false,s.spcheck,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.HasLevel,1,99,false,s.spcheck,nil)
	Duel.Release(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			if #g>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				g=g:Select(tp,1,1,nil)
			end
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.countval(e,re,sump)
	local ct=e:GetHandler():GetFlagEffect(id+sump)
	if ct>=4 then
		return 0
	else
		return 4-ct
	end
end