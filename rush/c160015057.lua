--メテオフレア・フュージョン
--Meteor Flare Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	Fusion.RegisterSummonEff{handler=c,extrafil=s.fextra,mincount=2,maxcount=2,stage2=s.stage2}
end
s.listed_names={CARD_REDEYES_B_DRAGON,CARD_SUMMONED_SKULL,64271667}
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,CARD_REDEYES_B_DRAGON,CARD_SUMMONED_SKULL,64271667)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND|LOCATION_MZONE,0,nil),s.checkmat
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 and not tc:IsType(TYPE_EFFECT) and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		g=g:AddMaximumCheck()
		Duel.HintSelection(g,true)
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end