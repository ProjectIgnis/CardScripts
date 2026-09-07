--未来融合－フューチャー・フュージョン・ノヴァ
--Future Fusion Nova
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: Fusion Summon 1 LIGHT Machine Fusion Monster from your Extra Deck, using monsters from your Deck, including "Cyber Dragon", also for the rest of this turn after this card resolves, you cannot Special Summon, except Machine monsters, also you cannot declare attacks, except with the Summoned monster
	local fusion_params={
			handler=c,
			fusfilter=function(c) return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) end,
			matfilter=aux.FALSE,
			extrafil=s.fextra,
			extratg=s.extratg,
			stage2=s.stage2
		}
	local e1=Fusion.CreateSummonEff(fusion_params)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--When this card leaves the field, destroy that monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(function(e) e:SetLabel(e:GetHandler():IsDisabled() and 1 or 0) end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.mondesop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--When that monster is destroyed, destroy this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.selfdescon)
	e4:SetOperation(function(e) Duel.Destroy(e:GetHandler(),REASON_EFFECT) end)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_CYBER_DRAGON}
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,CARD_CYBER_DRAGON)
end
function s.fextra(e,tp,mg1)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.stage2(e,fc,tp,sg,chk)
	if chk==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local c=e:GetHandler()
		c:SetCardTarget(fc)
		--For the rest of this turn after this card resolves, you cannot Special Summon, except Machine monsters
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsRaceExcept(RACE_MACHINE) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local fid=fc:GetFieldID()
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
		--Also you cannot declare attacks, except with the Summoned monster
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(function(e,c) return c:GetFieldID()~=fid end)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.mondesop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.selfdescon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end