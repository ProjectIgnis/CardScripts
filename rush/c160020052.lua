--ヴォイドダスト・フュージョン
--Void Dust Fusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon a Level 9 DARK Attribute Galaxy Type monster with 2000 or more DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)
end
function s.extrafusionmat(exc)
	return function(e,tp,mg)
		return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,exc),s.matexclusioncheck(exc)
	end
end
function s.matexclusioncheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc))
	end
end
function s.fusmonfilter(c)
	return c:IsLevel(9) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsDefenseAbove(2000)
end
function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsAbleToDeck()
end
function s.atklimit(e,sc,tp,sg,chk)
	if chk==0 then
		--Monsters other than the summoned monster cannot attack this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetLabel(sc:GetFieldID())
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsType(TYPE_NORMAL)) then return false end
	local fusion_params={fusfilter=s.fusmonfilter,
		matfilter=aux.FALSE,
		extrafil=s.extrafusionmat(c),
		extraop=Fusion.ShuffleMaterial,
		exactcount=2,
		stage2=s.atklimit
	}
	return Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local fusion_params={fusfilter=s.fusmonfilter,
		matfilter=aux.FALSE,
		extrafil=s.extrafusionmat(c),
		extraop=Fusion.ShuffleMaterial,
		exactcount=2,
		stage2=s.atklimit
	}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local req_c=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.HintSelection(req_c)
	Duel.SendtoDeck(req_c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,1)
	Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
end