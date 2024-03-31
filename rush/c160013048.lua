--ドラゴンズ・バースト・フュージョン
--Dragon's Burst Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,nil,Fusion.OnFieldMat(aux.FaceupFilter(Card.IsRace,RACE_DRAGON)),nil,nil,nil,s.stage2)
end
s.listed_names={CARD_BLUETOOTH_B_DRAGON}
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsCode(CARD_BLUETOOTH_B_DRAGON)
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==0 then
		local mg=tc:GetMaterial()
		local ct=mg:FilterCount(s.cfilter,nil)
		if ct>0 and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			--Reduce ATK
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-1500)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				g:GetFirst():RegisterEffect(e1)
			end
		end
	end
end
