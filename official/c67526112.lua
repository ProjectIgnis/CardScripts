--ラピッド・トリガー
--Rapid Trigger
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,extraop=s.extraop,stage2=s.stage2,matfilter=s.matfil,extratg=s.extratg}
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.matfil(c,e,tp,chk)
	return c:IsOnField() and c:IsDestructable(e) and not c:IsImmuneToEffect(e)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil,e,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,2,tp,LOCATION_ONFIELD)
end
function s.extraop(e,tc,tp,sg)
	local res=Duel.Destroy(sg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)==#sg
	sg:Clear()
	return res
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		--Limits the battle targets
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(s.atlimit)
		tc:RegisterEffect(e1,true)
		--Prevent direct attacks
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Immune
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(aux.Stringid(id,0))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		e3:SetValue(s.efilter)
		tc:RegisterEffect(e3,true)
	end
end
function s.atlimit(e,c)
	return not (c:IsSpecialSummoned() and c:IsSummonLocation(LOCATION_EXTRA))
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc:IsSpecialSummoned() and tc:IsSummonLocation(LOCATION_EXTRA) and tc~=e:GetHandler()
		and te:IsMonsterEffect() and te:IsActivated() and te:GetActivateLocation()==LOCATION_MZONE
end