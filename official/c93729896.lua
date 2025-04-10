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
	--Add 1 "Yubel" monster to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Keep track of the "Yubel" monsters that left the field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
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
function s.thfilter(c,tp,eg)
	return c:IsSetCard(SET_YUBEL) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsAbleToHand() and c:HasLevel()
		and eg:IsExists(s.lvfilter,1,nil,tp,c:GetOriginalLevel())
end
function s.lvfilter(c,tp,lv)
	local clv=c:GetOriginalLevel()
	return clv==lv+1 or clv==lv-1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp,eg) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_REMOVED|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp,eg):GetFirst()
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
			local new_label_obj=label_obj+g
			label_obj:DeleteGroup()
			new_label_obj:KeepAlive()
			e:SetLabelObject(new_label_obj)
		else
			e:SetLabelObject(g)
			g:KeepAlive()
			local c=e:GetHandler()
			--Raise the custom event at the end of the Chain
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EVENT_CHAIN_END)
			e1:SetRange(LOCATION_FZONE)
			e1:SetOperation(function()
								local g=e:GetLabelObject()
								e1:Reset()
								e:SetLabelObject(nil)
								Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,tp,ev)
								g:DeleteGroup()
							end
							)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end