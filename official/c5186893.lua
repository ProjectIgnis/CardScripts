--真紅眼の不死竜
--Red-Eyes Zombie Dragon
local s,id=GetID()
function s.initial_effect(c)
	--summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.otfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c==tc then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return tc:IsLocation(LOCATION_GRAVE) and tc:IsRace(RACE_ZOMBIE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	tc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
