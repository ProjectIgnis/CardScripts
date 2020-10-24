--
--Myutant Fusion
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x259),
										matfilter=Card.IsAbleToRemove,extrafil=s.extrafil,extraop=Fusion.BanishMaterial})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)
end
s.listed_series={0x259}
function s.check(g1,g2)
	return function(tp,sg,fc)
		local c1=#(sg&g1)
		local c2=#(sg&g2)
		return c1<=1 and c2<=1,c1>1 or c2>1
	end
end
function s.extrafil(e,tp,mg)
	if Duel.GetCustomActivityCount(id,1-e:GetHandlerPlayer(),ACTIVITY_CHAIN)==0 then return nil end
	local loc=LOCATION_DECK
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		loc=loc|LOCATION_GRAVE
	end
	local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,loc,0,mg)
	return g,s.check(g:Split(Card.IsLocation,nil,LOCATION_GRAVE))
end
