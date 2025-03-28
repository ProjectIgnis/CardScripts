--フュージョン・ミュートリアス
--Myutant Fusion
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_MYUTANT),
									matfilter=Card.IsAbleToRemove,extrafil=s.extrafil,
									extraop=Fusion.BanishMaterial,extratg=s.extrtarget})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)
end
s.listed_series={SET_MYUTANT}
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
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		loc=loc|LOCATION_GRAVE
	end
	local g=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,loc,0,mg)
	return g,s.check(g:Split(Card.IsLocation,nil,LOCATION_GRAVE))
end
function s.extrtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE|LOCATION_DECK)
end