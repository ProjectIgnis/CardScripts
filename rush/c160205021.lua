--サイバー・ラッシュ・ドラゴン
--Cyber Rush Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMixN(c,true,true,CARD_CYBER_DRAGON,2)
	--Draw up to 5 cards and discard 4 and Special Summon 1 monster from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.drwcond)
	e1:SetTarget(s.drwtg)
	e1:SetOperation(s.drwop)
	c:RegisterEffect(e1)
end
s.material_setcode={SET_CYBER,SET_CYBER_DRAGON}
function s.drwcond(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if chk==0 then return ct<5 and Duel.IsPlayerCanDraw(tp,5-ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5-ct)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,4)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if Duel.Draw(tp,5-ct,REASON_EFFECT)==5-ct then
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,4,4,nil)
		if #g==0 then return end
		Duel.BreakEffect()
		if Duel.SendtoGrave(g,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=sg:Select(tp,1,1,nil):GetFirst()
				if not sc then return end
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end