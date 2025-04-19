--融合解除 (Manga)
--De-Fusion (Manga)
--Updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Trap Spell
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	e3:SetDescription(aux.Stringid(id,1))
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local at=Duel.GetAttacker()
	if chkc then return chkc==at and at:IsType(TYPE_FUSION) and (at:IsAbleToExtra() or at:IsCode(10000010)) end
	if chk==0 then return at:IsOnField() and at:IsType(TYPE_FUSION)
		and (at:IsAbleToExtra() or at:IsCode(10000010)) and at:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(at)
	if not at:IsCode(10000010) then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,at,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_RECOVER)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,at:GetControler(),at:GetAttack())
	end
end
function s.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(c:GetOwner()) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&0x40008)==0x40008 and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	local p=tc:GetControler()
	if not tc:IsCode(10000010) then
		local mg=tc:GetMaterial()
		local ct=#mg
		if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
			if tc:IsFusionSummoned() and ct>0 and ct<=Duel.GetLocationCount(p,LOCATION_MZONE)
				and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,p,tc,mg)==ct
				and (ct<=1 or not Duel.IsPlayerAffectedByEffect(p,CARD_BLUEEYES_SPIRIT)) then
				Duel.SpecialSummon(mg,0,tp,p,false,false,POS_FACEUP)
			end
		end
	else
		local atk=tc:GetAttack()
		if tc:RegisterFlagEffect(FLAG_RA_DEFUSION,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
			and Duel.Recover(p,atk,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE,1)
		end
	end
end