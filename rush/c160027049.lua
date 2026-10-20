--Ｕ・メンテナンス
--Update Maintenance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon a Level 6 or lower LIGHT Attribute Dragon Type monster with 2000 or less ATK by shuffling Dragon Type monsters from your field or Graveyard into the owner's Deck as material. This turn, you cannot attack with Level 7 or higher monsters.
	local e1=Fusion.CreateSummonEff({
		handler=c,
		fusfilter=s.fusionmonsterfilter,
		matfilter=Fusion.OnFieldMat(s.matfilter),
		extrafil=s.extrafusionmaterial,
		extraop=s.showandshufflle,
		stage2=s.attacklimit,
	})
	e1:SetDescription(aux.Stringid(id,0))
	c:RegisterEffect(e1)
end
function s.fusionmonsterfilter(c)
	return c:IsLevelBelow(6) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsAttackBelow(2000)
end
function s.matfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
function s.extrafusionmaterial(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE,0,nil)
end
function s.showandshufflle(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsFacedown,nil)
	if #rg>0 then
		Duel.ConfirmCards(1-tp,rg)
	end
	Duel.HintSelection(sg,true)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
function s.attacklimit(e,tc,tp,mg,chk)
	if chk==0 then
		--This turn, you cannot attack with Level 7 or higher monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsLevelAbove(7) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end