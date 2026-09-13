--白鴉の魔女の幻姿
--Illusion of the White Crow Witch
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Illusion Fusion Monster from your Extra Deck, using monsters from your Extra Deck and/or field, also you cannot activate monster effects in the hand or GY for the rest of this turn after this card resolves, except Illusion monsters'
	local fusion_params={
		handler=c,
		fusfilter=function(c)
			return c:IsRace(RACE_ILLUSION)
		end,
		matfilter=Fusion.OnFieldMat,
		extrafil=function(e,tp,mg)
			return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_EXTRA,0,nil)
		end,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_EXTRA)
		end,
		stage2=function(e,tc,tp,mg,chk)
			if chk==2 then
				if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
				--Ylso you cannot activate monster effects in the hand or GY for the rest of this turn after this card resolves, except Illusion monsters'
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,2))
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetTargetRange(1,0)
				e1:SetValue(function(e,re,tp)
					local rc=re:GetHandler()
					return re:IsMonsterEffect() and rc:IsLocation(LOCATION_HAND|LOCATION_GRAVE) and rc:IsRaceExcept(RACE_ILLUSION)
				end)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	}
	--Fusion Summon 1 "Dragontail" Fusion Monster from your Extra Deck, using monsters from your hand, Deck, and/or field
	local e1=Fusion.CreateSummonEff(fusion_params)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If the activation of this card in its owner's possession was negated by an opponent's card effect and sent to your GY: You can Set this card, and if you do, return all cards your opponent controls to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return re:GetHandler()==e:GetHandler() and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp and de and dp==1-tp
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end