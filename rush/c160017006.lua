--ハイブリッドライブ・スクリュードライバー
--Hybridrive Screwdriver
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster on your opponent's field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_DRAGON|RACE_MACHINE) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,0)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsRace,nil,RACE_DRAGON)==2 and sg:FilterCount(Card.IsRace,nil,RACE_MACHINE)==2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local rqg=aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,1,tp,HINTMSG_TODECK)
	if #rqg==0 then return end
	Duel.HintSelection(rqg,true)
	if Duel.SendtoDeck(rqg,nil,SEQ_DECKBOTTOM,REASON_COST)==0 then return end
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #og>0 then Duel.SortDeckbottom(tp,tp,#og) end
	--Effect
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		local tc=sg:GetFirst() --should be done before the Maximum check to ensure that the center's part name is the one used for the effect
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg,true)
		if Duel.Destroy(sg,REASON_EFFECT)>0 then
			--Can only Special Summon in face-down Defense Position
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,1)
			e1:SetTarget(s.sumlimit)
			e1:SetLabel(tc:GetOriginalCodeRule())
			e1:SetValue(POS_FACEDOWN_DEFENSE)
			e1:SetReset(RESET_PHASE|PHASE_END,2)
			Duel.RegisterEffect(e1,tp)
			--Prevent players from Special Summoning monsters with the same name
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,1))
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_SUMMON)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetTargetRange(1,1)
			e2:SetTarget(s.sumlimit)
			e2:SetLabel(tc:GetOriginalCodeRule())
			e2:SetReset(RESET_PHASE|PHASE_END,2)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsOriginalCodeRule(e:GetLabel())
end