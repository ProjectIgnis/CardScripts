--ラピッド・トリガー
--Rapid Trigger
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,extraop=s.extraop,stage2=s.stage2})
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,0x1e0)
	local tg=e1:GetTarget()
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					tg(e,tp,eg,ep,ev,re,r,rp,chk) 
					Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil),1,tp,LOCATION_ONFIELD)
				end)
	c:RegisterEffect(e1)
end
function s.extraop(e,tc,tp,sg)
	Duel.Destroy(sg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		--cannot be battle target
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetTarget(s.attg)
		e1:SetValue(s.atlimit)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		--immune
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(aux.Stringid(id,0))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(s.efilter)
		tc:RegisterEffect(e3)
	end
end
function s.attg(e,c)
	return not (c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetSummonLocation()==LOCATION_EXTRA)
end
function s.atlimit(e,c)
	return c==e:GetHandler()
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc:IsSummonType(SUMMON_TYPE_SPECIAL) and tc:GetSummonLocation()==LOCATION_EXTRA and tc~=e:GetHandler()
end