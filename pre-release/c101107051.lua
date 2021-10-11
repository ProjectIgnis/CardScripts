--究極融合
--Ultimate Fusion
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=s.ffilter,matfilter=Card.IsAbleToDeck,
									 extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,stage2=s.desop})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON,23995346}
function s.ffilter(c)
	return aux.IsCodeListed(c,CARD_BLUEEYES_W_DRAGON,23995346)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.desfilter(c)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON,23995346) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.desop(e,tc,tp,mg,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		local mc=mg:FilterCount(s.desfilter,nil)
		if #g>0 and mc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,mc,nil)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end