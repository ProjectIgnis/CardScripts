--古代の機械競闘
--Ancient Gear Duel
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--"Ancient Gear Golem" and monsters that mention it are unaffected by your opponent's activated monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(function(e,c) return c:IsCode(CARD_ANCIENT_GEAR_GOLEM) or c:ListsCode(CARD_ANCIENT_GEAR_GOLEM) end)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--Fusion Summon 1 Fusion Monster that mentions "Ancient Gear Golem"
	local params={fusfilter=function(c) return c:ListsCode(CARD_ANCIENT_GEAR_GOLEM) end,
					matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),
					extrafil=s.fmatextra,
					extratg=s.extratarget,
					extraop=Fusion.BanishMaterial,
					stage2=s.stage2}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end)
	e3:SetTarget(Fusion.SummonEffTG(params))
	e3:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ANCIENT_GEAR_GOLEM}
function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated() and te:IsMonsterEffect()
end
function s.aggfilter(c,tp)
	return c:IsCode(CARD_ANCIENT_GEAR_GOLEM) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(s.aggfilter,1,nil,tp)
end
function s.fmatextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil),s.fcheck
	end
	return nil,s.fcheck
end
function s.extratarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Can make up to 3 attacks during each Battle Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end