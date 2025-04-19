--天融星カイキ (Anime)
--Kaiki the Unity Star (Anime)
Duel.EnableUnofficialProc(PROC_STATS_CHANGED)
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local params = {nil,Fusion.IsMonsterFilter,nil,nil,nil,s.stage2}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.fuscost)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(id)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetCondition(s.damcon)
		e1:SetOperation(s.damop)
		e1:SetReset(RESET_EVENT|0x3fe0000)
		tc:RegisterEffect(e1)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(tp,500,REASON_EFFECT)
end
function s.cfilter(c,tp)
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	return c:IsType(TYPE_FUSION) and c:IsControler(tp) and c:GetAttack()~=val
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.SelectEffectYesNo(tp,c) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end