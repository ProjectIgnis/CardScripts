--未来融合－フューチャー・フュージョン (Anime)
--Future Fusion (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=aux.FALSE,extrafil=s.fextra,stage2=s.stage2,extratg=s.extratg})
	c:RegisterEffect(e1)
end
function s.fextra(e,tp,mg1)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.stage2(e,tc,tp,sg,chk)
	local c=e:GetHandler()
	if chk==0 then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		--Cannot attack this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1,true)
		--Cannot be Tributed
		local e2=e1:Clone()
		e2:SetDescription(3303)
		e2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e3,true)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_UNRELEASABLE_EFFECT)
		tc:RegisterEffect(e4,true)
	end
	if chk==1 then
		if Duel.Equip(tp,c,tc) then
			--Equip limit
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e5:SetCode(EFFECT_EQUIP_LIMIT)
			e5:SetValue(function(e,c) return c==tc end)
			e5:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e5)
			--Destroy the Summoned monster when this card is destroyed
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e6:SetCode(EVENT_DESTROYED)
			e6:SetOperation(s.desop)
			c:RegisterEffect(e6)
		end
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetPreviousEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) and tc:HasFlagEffect(id) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
	e:Reset()
end