--団結する剣闘獣
--Gladiator Beast United
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_ATTACK,s.counterfilter)
end
s.listed_series={0x19}
function s.counterfilter(c)
	return c:IsSetCard(0x19)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_ATTACK)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.atktg(e,c)
	return not s.counterfilter(c)
end
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,chkf)
	return c:IsSetCard(0x19) and c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:CheckFusionMaterial(m,nil,chkf|FUSPROC_NOTFUSION|FUSPROC_LISTEDMATS)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
		return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.cffilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp|FUSPROC_NOTFUSION|FUSPROC_LISTEDMATS
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,e)
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
		local cf=mat:Filter(s.cffilter,nil)
		if #cf>0 then
			Duel.ConfirmCards(1-tp,cf)
		end
		Duel.SendtoDeck(mat,nil,2,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
