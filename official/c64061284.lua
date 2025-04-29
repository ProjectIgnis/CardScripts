--古代の機械融合
--Ancient Gear Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 "Ancient Gear" Fusion Monster from your Extra Deck, using monsters from your hand or field as Fusion Material
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=function(c) return c:IsSetCard(SET_ANCIENT_GEAR) end,extrafil=s.fextra,extratg=s.extratg})
	c:RegisterEffect(e1)
end
s.listed_series={SET_ANCIENT_GEAR}
s.listed_names={CARD_ANCIENT_GEAR_GOLEM,95735217} --"Ancient Gear Golem - Ultimate Pound"
function s.filterchk(c)
	return c:IsCode(CARD_ANCIENT_GEAR_GOLEM,95735217) and c:IsOnField()
end
function s.fcheck(tp,sg,fc)
	if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		return sg:IsExists(s.filterchk,1,nil) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filterchk,1,nil) then
		local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end