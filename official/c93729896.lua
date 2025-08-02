--ナイトメア・スローン
--Nightmare Throne
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Keep track of the "Yubel" monsters that left the field
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_LEAVE_FIELD)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetCondition(s.regcon)
	e2a:SetOperation(s.regop)
	c:RegisterEffect(e2a)
	--Add 1 "Yubel" monster to your hand
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetProperty(EFFECT_FLAG_DELAY)
	e2b:SetCode(EVENT_CUSTOM+id)
	e2b:SetRange(LOCATION_FZONE)
	e2b:SetCountLimit(1)
	e2b:SetCondition(function(e,tp,eg,ep) return ep==tp end)
	e2b:SetTarget(s.thtg)
	e2b:SetOperation(s.thop)
	e2b:SetLabelObject(e2a)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_YUBEL}
function s.thdesfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttack(0) and c:IsDefense(0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thdesfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
		aux.ToHandOrElse(sc,tp,nil,function() Duel.Destroy(sc,REASON_EFFECT) end,aux.Stringid(id,3))
	end
end
function s.thfilter(c,tp,levels)
	if not (c:IsSetCard(SET_YUBEL) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsAbleToHand() and c:HasLevel()) then return false end
	for _,lv in ipairs(levels) do
		if c:IsOriginalLevel(lv-1) or c:IsOriginalLevel(lv+1) then
			return true
		end
	end
	return false
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local levels={e:GetLabelObject():GetLabel()}
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp,levels) end
	e:SetLabel(table.unpack(levels))
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_REMOVED|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp,{e:GetLabel()}):GetFirst()
	if not sc then return end
	if sc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) then Duel.HintSelection(sc,true) end
	if not (Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND)) then return end
	Duel.ConfirmCards(1-tp,sc)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
	end
end
function s.thconfilter(c,tp)
	return c:IsPreviousSetCard(SET_YUBEL) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_EFFECT) and c:HasLevel()
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thconfilter,1,nil,tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.thconfilter,nil,tp)
	if not Duel.IsChainSolving() then
		Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,tp,ev)
	else
		local label_obj=e:GetLabelObject()
		if label_obj then
			label_obj:Merge(g)
			local levels={e:GetLabel()}
			for tc in g:Iter() do
				table.insert(levels,tc:GetOriginalLevel())
			end
			e:SetLabel(table.unpack(levels))
		else
			e:SetLabel(table.unpack(g:GetClass(Card.GetOriginalLevel)))
			e:SetLabelObject(g)
			local c=e:GetHandler()
			--Raise the custom event at the end of the Chain
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetRange(LOCATION_FZONE)
			e1:SetCondition(function() return Duel.GetCurrentChain()==1 end)
			e1:SetOperation(function(eff)
						local g=e:GetLabelObject()
						eff:Reset()
						e:SetLabelObject(nil)
						if g then
							Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,tp,ev)
						end
					end)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EVENT_CHAIN_NEGATED)
			c:RegisterEffect(e2)
		end
	end
end
