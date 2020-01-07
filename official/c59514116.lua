--黒魔術の秘儀
--Dark Magic Secrets
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Fusion
	c:RegisterEffect(Fusion.CreateSummonEff({handler=c,desc=aux.Stringid(id,0),extrafil=function()return nil,s.matcheck end}))
	--Ritual
	Ritual.AddProc({handler=c,lvtype=RITPROC_GREATER,desc=aux.Stringid(id,1),forcedselection=s.forcedselection})
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL}
function s.matcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSummonCode,1,nil,fc,SUMMON_TYPE_FUSION,tp,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)
end
function s.forcedselection(e,tp,sg,sc)
	return sg:IsExists(Card.IsCode,1,nil,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)
end
