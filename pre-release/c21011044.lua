--影依の偽典
--Shaddoll Ruq
--scripted by Naim and edo9300
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--fusion
	local e2=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x9d),matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),
									extrafil=s.fextra,extraop=Fusion.BanishMaterial,stage2=s.sstage2,desc=aux.Stringid(id,0)})
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e2)
end
s.listed_series={0x9d}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
end
function s.sstage2(e,tc,tp,sg,chk)
	if chk==1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local att=tc:GetAttribute()
		if Duel.IsExistingMatchingCard(s.sameatt,tp,0,LOCATION_MZONE,1,nil,att) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local tgc=Duel.SelectMatchingCard(tp,s.sameatt,tp,0,LOCATION_MZONE,1,1,nil,att):GetFirst()
			if tgc then
				Duel.SendtoGrave(tgc,REASON_EFFECT)
			end
		end
	end
end
function s.sameatt(c,att)
	return c:IsFaceup() and c:IsAttribute(att) and c:IsAbleToGrave()
end

