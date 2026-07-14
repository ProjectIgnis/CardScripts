--救惺の轟拳 フィスト
--Fist the Star Protector's Roaring Gauntlet
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Excavate and Fusion Summon
	local params = {s.fusfilter,nil,nil,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.fusfilter(c)
	return c:IsCode(160026037)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.filter(c)
	return c:IsCode(160026047) and c:IsAbleToGrave()
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		--Effect
		local canFusion=false
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
		Duel.ConfirmDecktop(tp,4)
		local g=Duel.GetDecktopGroup(tp,4)
		Duel.DisableShuffleCheck()
		if g:IsExists(s.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:FilterSelect(tp,s.filter,1,1,nil)
			if Duel.SendtoGrave(sg,REASON_EFFECT)>0 then canFusion=true end
			Duel.BreakEffect()
			g:RemoveCard(sg)
		end
		local ct=#g
		if ct>0 then
			Duel.MoveToDeckBottom(ct,tp)
			Duel.SortDeckbottom(tp,tp,ct)
		end
		if canFusion and fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end